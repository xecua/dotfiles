#!/usr/bin/perl

$latex = 'find . -type f -name "*.tex" -print0 | xargs -0 sed -i "" -e "s/、/，/g" -e "s/。/．/g"; /Library/TeX/texbin/uplatex -kanji=utf-8 -halt-on-error -interaction=nonstopmode -file-line-error -synctex=1';
$latex_silent = 'find . -type f -name "*.tex" -print0 | xargs -0 sed -i "" -e "s/、/，/g" -e "s/。/．/g"; /Library/TeX/texbin/uplatex -kanji=utf-8 -halt-on-error -interaction=batchmode -file-line-error -synctex=1';
$lualatex = 'find . -type f -name "*.tex" -print0 | xargs -0 sed -i "" -e "s/、/，/g" -e "s/。/．/g"; /Library/TeX/texbin/lualatex -interaction=nonstopmode -synctex=1S';
$dvipdf = '/Library/TeX/texbin/dvipdfmx -o %D %S';
$bibtex = '/Library/TeX/texbin/pbibtex';
$makeindex = '/Library/TeX/texbin/mendex';
$pdf_mode = 3;
$pdf_previewer = '/Applications/Skim.app/Contents/MacOS/Skim';
$max_repeat = 5;
$out_dir = 'out';

$pvc_view_file_via_temporary = 0;