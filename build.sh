#!/usr/bin/env bash

#clitool="asciidoctor-revealjs"
clitool="asciidoctor-revealjs -a highlightjsdir=highlight --trace -v -r asciidoctor-diagram"
version=4.1.0
#cmd="$clitool presentation.adoc"
#Commande pour les slides
cmd="$clitool adoc_les_modules/*.adoc"

#Commande pour les supports formateur en pdf

cmd_pdf_formateur="asciidoctor-pdf -a toc --trace -v -r asciidoctor-diagram -a formateur=yes -D public/formateur/pdf adoc_les_modules/*.adoc"
cmd_pdf_apprenant="asciidoctor-pdf -a toc --trace -v -r asciidoctor-diagram -a formateur=no -D public/apprenant/pdf adoc_les_modules/*.adoc"

cmd_html_formateur="asciidoctor -a toc --trace -v -r asciidoctor-diagram -a formateur=yes -D public/formateur/html adoc_les_modules/*.adoc"
cmd_html_apprenant="asciidoctor -a toc --trace -v -r asciidoctor-diagram -a formateur=no -D public/apprenant/html adoc_les_modules/*.adoc"

mkdir -p public/formateur/pdf public/apprenant/pdf public/formateur/html public/apprenant/html

if ! $clitool --version | grep $version > /dev/null; then
    echo "$clitool $version not installed"
    echo "running build via docker..."
    docker run --rm -v "$PWD:/src" -w "/src" asciidoctor/docker-asciidoctor:1.6.0 $cmd

    find . -type f -name "*.html" -print0 | xargs -0 sed -i 's/rainbow/rainbow.css/g'

    docker run --rm -v "$PWD:/src" -w "/src" asciidoctor/docker-asciidoctor:1.6.0 $cmd_pdf_formateur
    docker run --rm -v "$PWD:/src" -w "/src" asciidoctor/docker-asciidoctor:1.6.0 $cmd_pdf_apprenant
    docker run --rm -v "$PWD:/src" -w "/src" asciidoctor/docker-asciidoctor:1.6.0 $cmd_html_formateur
    docker run --rm -v "$PWD:/src" -w "/src" asciidoctor/docker-asciidoctor:1.6.0 $cmd_html_apprenant
    #docker run --rm -v "$PWD:/src" -w "/src" asciidoctor/docker-asciidoctor-revealjs --trace -v -r asciidoctor-diagram *.doc
else
    echo "$clitool $version installed!"
    echo "running build..."
    $cmd
fi

if [ ! -r ./public ]; then
    mkdir -p public
fi


cp -a adoc_les_modules/*.html public
cp -r reveal.js/rainbow.css public/
cp -r reveal.js/ public/
cp -r highlight/ public/
cp -r reveal.js/ public/apprenant/html/
cp -r reveal.js/ public/formateur/html/
cp -r images/ public/
cp -r Démonstrations/ public/

rm index.html
mv -f public/formateur/html/index.html public/index.html

