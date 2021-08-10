function pv_name = remove_dots(pv)

pv_name = strrep(pv,':','_');
pv_name = strrep(pv_name,'.','_');