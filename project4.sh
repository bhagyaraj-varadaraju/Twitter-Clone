rm ebin/*.beam

mkdir ebin

erlc -o ebin src/*.erl

erl -pa "ebin" -eval "simulator:main()." -s init stop -noshell
