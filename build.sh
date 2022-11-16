#!/usr/bin/env bash

#clitool="asciidoctor-revealjs"
clitool="asciidoctor-revealjs -a highlightjsdir=highlight --trace -v -r asciidoctor-diagram"
version=4.1.0
#cmd="$clitool presentation.adoc"
#Commande pour les slides
cmd="$clitool adoc_les_modules/*.adoc"

#Commande pour les supports formateur en pdf

#Commande pour les supports FORMATEUR
cmd_pdf_formateur="asciidoctor-pdf -a toc --trace -v -r asciidoctor-diagram -a formateur=yes -a dv=yes -a ndv=yes -D public/formateur/pdf adoc_les_modules/*.adoc"
cmd_html_formateur="asciidoctor -a toc --trace -v -r asciidoctor-diagram -a formateur=yes -a dv=yes -a ndv=yes -D public/formateur/html adoc_les_modules/*.adoc"

#Commande pour les supports apprenants
cmd_html_apprenant="asciidoctor -a toc --trace -v -r asciidoctor-diagram -a formateur=no -a dv=no -a ndv=yes -D public/apprenant/html adoc_les_modules/*.adoc"
cmd_pdf_apprenant="asciidoctor-pdf -a toc --trace -v -r asciidoctor-diagram -a formateur=no -a dv=no -a ndv=yes -D public/apprenant/pdf adoc_les_modules/*.adoc"

#Commande pour les supports dv
cmd_html_dv="asciidoctor -a toc --trace -v -r asciidoctor-diagram -a formateur=no -a dv=yes -a ndv=no -D public/dv/html adoc_les_modules/*.adoc"
cmd_pdf_dv="asciidoctor-pdf -a toc --trace -v -r asciidoctor-diagram -a formateur=no -a dv=yes -a ndv=no -D public/dv/pdf adoc_les_modules/*.adoc"

mkdir -p public/formateur/pdf public/apprenant/pdf public/formateur/html public/apprenant/html
mkdir -p public/dv/pdf public/dv/html

if ! $clitool --version | grep $version > /dev/null; then
    echo "$clitool $version not installed"
    echo "running build via docker..."
    docker run --rm -v "$PWD:/src" -w "/src" asciidoctor/docker-asciidoctor:1.6.0 $cmd

    find . -type f -name "*.html" -print0 | xargs -0 sed -i 's/rainbow/rainbow.css/g'
    find . -type f -name "*.html" -print0 | xargs -0 sed -i 's/.\/..\/images/.\/images/g'#TODO Gestion img 4 diapos

    docker run --rm -v "$PWD:/src" -w "/src" asciidoctor/docker-asciidoctor:1.6.0 $cmd_pdf_formateur
    docker run --rm -v "$PWD:/src" -w "/src" asciidoctor/docker-asciidoctor:1.6.0 $cmd_html_formateur

    docker run --rm -v "$PWD:/src" -w "/src" asciidoctor/docker-asciidoctor:1.6.0 $cmd_pdf_apprenant
    docker run --rm -v "$PWD:/src" -w "/src" asciidoctor/docker-asciidoctor:1.6.0 $cmd_html_apprenant

    docker run --rm -v "$PWD:/src" -w "/src" asciidoctor/docker-asciidoctor:1.6.0 $cmd_html_dv
    docker run --rm -v "$PWD:/src" -w "/src" asciidoctor/docker-asciidoctor:1.6.0 $cmd_pdf_dv
    #docker run --rm -v "$PWD:/src" -w "/src" asciidoctor/docker-asciidoctor-revealjs --trace -v -r asciidoctor-diagram *.doc
else
    echo "$clitool $version installed!"
    echo "running build..."
    $cmd
fi

if [ ! -r ./public ]; then
    mkdir -p public
fi




# Copie les répertoires du sous-module dans public
cp -r Config-DAC/reveal.js/rainbow.css public/
cp -r Config-DAC/reveal.js/ public/
cp -r Config-DAC/highlight/ public/
cp -r Config-DAC/reveal.js/ public/apprenant/html/
cp -r Config-DAC/reveal.js/ public/formateur/html/
cp -r Config-DAC/reveal.js/ public/dv/html/

# Copie les répertoires dans public et les zones pour chaque type de supports
cp -a adoc_les_modules/*.html public
cp -r images/ public/
cp -r images/ public/apprenant/
cp -r images/ public/formateur/
cp -r images/ public/dv/
cp -r contenu_des_demonstrations/ public/

rm index.html
mv -f public/formateur/html/index.html public/index.html


