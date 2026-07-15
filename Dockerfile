FROM gcc:latest

WORKDIR /app

COPY . .


RUN apt-get update && apt-get install -y bison flex

RUN bison -d parser.y
RUN flex lexer.l

RUN gcc -o interpreter main.c lex.yy.c parser.tab.c -lfl

CMD ["./interpreter"]
