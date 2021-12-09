function [ colNum ] = xlsColStr2Num( colChar )
%XLSCOLSTR2NUM takes in a cellular array of characters
%and returns a array of numbers of the same size with elements 
%corresponding to Excel column numbers.
%
%For example:
%c={'A' , 'J';
%   'BA', 'IV'}
%n=xlsColNum2Str(c);
%n=[1  10;
%   53 256]
%Note: up to Excel 2003 the number of columns was limited to 256, as of
%Excel 2007 the number of columns has increased to 16,384 or 'XFD'
%This function is designed to take accept any string so proper handling 
%of the number of columns should be taken care of outside this function

colNum=cellfun(@(x) (sum((double(x)-64).*26.^(length(x)-1:-1:0))),...
    colChar);