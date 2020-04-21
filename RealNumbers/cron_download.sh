#!/usr/bin/sh
curl https://data.brasil.io/dataset/covid19/obito_cartorio.csv.gz -o /home/mavila/devel/corona/data/brasilio/cartorio/$(date +%Y_%m_%d).csv.gz
