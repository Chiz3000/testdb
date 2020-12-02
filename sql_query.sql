--Какой средний возраст клиентов, купивших плюшевого мишку (TEDDY) в 2018 году?
select avg(AGE) as "Средний возраст"
from customer c 
join purchase pu
on c.customer_key=pu.customer_key
join product pr
on pu.product_key = pr.product_key
where 
pr.name='TEDDY'
and pu."DATE" between to_date('01.01.2018','DD.MM.YYYY') and to_date('31.12.2018','DD.MM.YYYY') ;

--ФИО покупателей, которые приобретали одновременно TEDDY и LEGO в 2018 года;
select c.FIO 
from (
select customer_key,product_key,
row_number() over (partition by customer_key order by customer_key, product_key) as rnum
from purchase
where product_key in (1,6) and "DATE" between to_date('01.01.2018','DD.MM.YYYY') and to_date('31.12.2018','DD.MM.YYYY') 
) rn 
join customer c
on rn.customer_key=c.customer_key
where rnum>=2

--Топ-3 самых продаваемых товара в категории TOYS  за 2018 год в разбивке по месяцам?
select NAME as "Товар", mon as "Месяц"
from (
select rr.product_key ,pr.NAME , mon , sumQTY ,
row_number() over (partition by mon order by sumQTY desc ) as rn
from (
select  distinct product_key,
extract(month from "DATE") as mon,
sum(QTY) over (partition by product_key, extract(month from "DATE") order by extract(month from "DATE")) as sumQTY
from purchase
order by extract(month from "DATE")
) rr
join product pr 
on rr.product_key=pr.product_key
join product_category pc
on pr.category_key = pc.category_key
where pc.category='TOYS'
) prod
where rn<=3

--ФИО клиентов, у которых сумма покупок за майские праздники превышает 20000 рублей.
select * from (
select c.FIO,pu.customer_key,sum(pu.QTY*pr.price) as ss
from purchase pu
join product pr
on pu.product_key = pr.product_key
join customer c
on c.customer_key=pu.customer_key
where pu."DATE" in ( to_date('01.05.2018','DD.MM.YYYY') ,to_date('02.05.2018','DD.MM.YYYY') ,to_date('03.05.2018','DD.MM.YYYY') , to_date('08.05.2018','DD.MM.YYYY') ,to_date('09.05.2018','DD.MM.YYYY'))
group by c.FIO,pu.customer_key
)
where ss>20000