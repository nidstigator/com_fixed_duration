function []=  write_to_file(mat_name, csv_name,  header, matdata, csvdata)

save(mat_name, 'matdata');

fid = fopen(csv_name, 'w') ;
fprintf(fid, '%s,', header{1,1:end-1}) ;
fprintf(fid, '%s\n', header{1,end}) ;
fclose(fid) ;
dlmwrite(csv_name, csvdata(1:end,:), '-append') ;

end