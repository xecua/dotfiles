#!/usr/bin/perl

$latex = 'uplatex -kanji=utf-8 -halt-on-error -interaction=nonstopmode -file-line-error -synctex=1 %S';
$latex_silent = 'uplatex -kanji=utf-8 -halt-on-error -interaction=batchmode -file-line-error -synctex=1 %S';
$lualatex = 'lualatex %O -interaction=nonstopmode -synctex=1 %S';
$dvipdf = 'dvipdfmx %S';
$bibtex = 'pbibtex';
$makeindex = 'mendex %O -o %D %S';
$pdf_mode = 3;
# $pdf_update_method = 2;
$pdf_previewer = '"/mnt/c/Program Files/SumatraPDF/SumatraPDF.exe" -reuse-instance %O %S';
$pdf_update_command = '"/mnt/c/Program Files/SumatraPDF/SumatraPDF.exe" -reuse-instance %O %S';
$max_repeat = 5;

$pvc_view_file_via_temporary = 0;
