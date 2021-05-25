create database livraria_atividade 

go 

use livraria_atividade

go 
create table cliente(
cod				int				not null, 
nome			varchar(80)		not null,
logradouro		varchar(100),
numero			int,
telefone		char(9)

primary key(cod)
)

go

select*from corredor 

create table corredor(

cod			int				not null,
tipo		varchar(50)		not null

primary key(cod)
)

go

select*from autores

create table autores(
cod				int				not null,
nome			varchar(70)		not null,
pais			varchar(15)		not null,
biografia		varchar(200)	not null

primary key(cod)

)

go

select*from livros

create table livros(
	
cod					int				not null,
cod_autor			int				not null,
cod_corredor		int				not null,
nome				varchar(50)		not null,
pag					int				not null,
idioma				varchar(30)		not null

primary key(cod) 
foreign key(cod_autor) references autores(cod),
foreign key(cod_corredor) references corredor(cod)

)

go

select*from emprestimo

create table emprestimo(

cod_cli				int			not null,
data				datetime	not null,
cod_livro			int			not null

primary key(cod_cli,data,cod_livro)

foreign key(cod_cli) references cliente(cod),
foreign key(cod_livro) references livros(cod)


)

-- 1) Fazer uma consulta que retorne o nome do cliente e a data do empréstimo formatada padrão BR (dd/mm/yyyy)
select distinct c.nome, CONVERT(char(10), e.data,103) as data_emprestimo
from cliente c, emprestimo e
where c.cod = e.cod_cli

--2) Fazer uma consulta que retorne Nome do autor e Quantos livros foram escritos por Cada autor, ordenado pelo número de livros. Se o nome do autor tiver mais de 25 caracteres, mostrar só os 13

select case
	when  len(a.nome) > 25 then
		SUBSTRING(a.nome, 1, 13)+ '...'
	else 
		a.nome
	end as nome_autor,
 count(l.cod_autor) as numero_de_livros
from autores a, livros l 
where a.cod = l.cod_autor
group by a.nome
order by numero_de_livros

-- 3) Fazer uma consulta que retorne o nome do autor e o país de origem do livro com maior número de páginas cadastrados no sistema

select a.nome, a.pais 
from autores a, livros l
where a.cod = l.cod_autor
and l.pag in 
(
select max(pag)
from livros
)


--4) Fazer uma consulta que retorne nome e endereço concatenado dos clientes que tem livros emprestados

SELECT distinct c.nome, c.logradouro + ' '+ convert(char(10), c.numero)  as endereco
FROM  cliente c LEFT OUTER JOIN emprestimo e
ON c.cod = e.cod_cli
WHERE e.cod_cli is not null

/*5) Nome dos Clientes, sem repetir e, concatenados como
enderço_telefone, o logradouro, o numero e o telefone) dos
clientes que Não pegaram livros. Se o logradouro e o 
número forem nulos e o telefone não for nulo, mostrar só o telefone.
Se o telefone for nulo e o logradouro e o número não forem nulos, mostrar só logradouro e número. Se os três existirem, mostrar os três.
O telefone deve estar mascarado XXXXX-XXXX 
*/


select c.nome, 
case 
when (c.logradouro is null and c.numero is null) then 
	substring(c.telefone,1,5) +'-'+substring(c.telefone,6,9)
	else
		case when c.telefone is null then 
			c.logradouro + ' '+ convert(char(10), c.numero)
		else
			c.logradouro + ' '+ convert(char(10), c.numero) +' '+ convert(char(5), substring(c.telefone,1,5)) +'-'+ convert(char(4), substring(c.telefone,4,9)) 
		end
end as endereco_telefone
FROM  cliente c LEFT OUTER JOIN emprestimo e
ON c.cod = e.cod_cli
WHERE e.cod_cli is null

--'6) Fazer uma consulta que retorne Quantos livros não foram emprestados
select l.nome
FROM  livros l LEFT OUTER JOIN emprestimo e
ON l.cod = e.cod_livro
WHERE e.cod_livro is null


-- 7) Fazer uma consulta que retorne Nome do Autor, Tipo do corredor e quantos livros, ordenados por quantidade de livro

select a.nome, c.tipo, count(l.cod) as qtde_livros
from autores a, corredor c, livros l 
where a.cod = l.cod_autor
	and l.cod_corredor = c.cod
group by a.nome, c.tipo
order by qtde_livros

/*8) Considere que hoje é dia 18/05/2012, faça uma consulta que apresente o 
nome do cliente, o nome do livro, o total de dias que cada um está com o livro e, uma coluna que apresente, caso o
*/

select  c.nome, l.nome, DATEDIFF(DAY, e.data, '2012-05-18') as qtde_dias,
case when DATEDIFF(DAY, e.data, '2012-05-18') > 4 then
	'Atrasado'
else
	'No prazo'
end as prazo
from cliente c, livros l, emprestimo e
where c.cod = e.cod_cli
	and e.cod_livro = l.cod
order by c.nome, l.nome

--9) Fazer uma consulta que retorne cod de corredores, tipo de corredores e quantos livros tem em cada corredor
select c.cod, c.tipo, count(l.cod) as qtde_livros
from corredor c, livros l
where c.cod = l.cod_corredor
group by c.cod, c.tipo

--10) Fazer uma consulta que retorne o Nome dos autores cuja quantidade de livros cadastrado é maior ou igual a 2.

select a.nome
from autores a, livros l
where a.cod = l.cod_autor
group by a.nome
having count(l.cod_autor) >=2

--11) Considere que hoje é dia 18/05/2012, faça uma consulta que apresente o nome do cliente, o nome do livro dos empréstimos que tem 7 dias ou mais

select c.nome, l.nome
from cliente c, livros l, emprestimo e
where c.cod = e.cod_cli	
	and e.cod_livro = l.cod
group by c.nome, l.nome, e.data
having DATEDIFF(DAY, e.data, '2012-05-18') > 7