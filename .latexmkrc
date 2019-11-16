#!/usr/bin/perl

$latex = 'find . -type f -name "*.tex" -print0 | xargs -0 sed -i "" -e "s/、/，/g" -e "s/。/．/g"; uplatex -kanji=utf-8 -halt-on-error -interaction=nonstopmode -file-line-error -synctex=1';
$latex_silent = 'find . -type f -name "*.tex" -print0 | xargs -0 sed -i "" -e "s/、/，/g" -e "s/。/．/g"; uplatex -kanji=utf-8 -halt-on-error -interaction=batchmode -file-line-error -synctex=1';
$lualatex = 'find . -type f -name "*.tex" -print0 | xargs -0 sed -i "" -e "s/、/，/g" -e "s/。/．/g"; lualatex -interaction=nonstopmode -synctex=1S';
$dvipdf = 'dvipdfmx -o %D %S';
$bibtex = 'pbibtex';
$makeindex = 'mendex';
$pdf_mode = 3;
$pdf_previewer = '/Applications/Skim.app/Contents/MacOS/Skim';
$max_repeat = 5;
$out_dir = 'out';

$pvc_view_file_via_temporary = 0;
