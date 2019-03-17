function []=  write_to_file(csv_name,  header, csvdata)

fid = fopen(csv_name, 'w') ;
fprintf(fid, '%s,', header{1,1:end-1}) ;
fprintf(fid, '%s\n', header{1,end}) ;
fclose(fid) ;
dlmwrite(csv_name, csvdata(1:end,:), '-append') ;

end