%macro check_reference_data(
	ref_lib 	/* location of reference data */,
	ref_table 	/* name of reference table for comparison */,
	in_lib 		/* location of input data to compare */,
	in_table 	/* name of input table to compare */,
	out_result 	/* new data set to hold result */
);
proc sql;

  create view WORK._TMPIN as
  select * from &in_lib..&in_table.;

  create table &out_result. as
    select 
      "&in_table." as NEW_DT,
	  "&ref_table." as OLD_DT,
      a.name as old_name, b.name, 
      a.length as old_length, b.length,
      a.type as ref_type, b.type,
      a.format as old_format, b.format,
      case 
        when b.name is missing then 
			'SEV-1: COLUMN is MISSING '
        when a.name is missing then 
			'SEV-4: EXTRA COLUMN'
        when b.type <> a.type then 
			'SEV-1: MISMATCHED TYPE'
        when b.length > a.length then 
			'SEV-2: MISMATCHED LENGTH, POSSIBLE TRUNCATION '
        when b.format <> a.format then 
			'SEV-3: MISMATCHED FORMAT, POSSIBLE MISINTERPRETATION'       
        else 
			'OK'
      end as RULE
    from 
      (select name, length, type, format from sashelp.vcolumn 
        where libname="&ref_lib" and memname="&ref_table") a FULL JOIN
      (select name, length, type, format from sashelp.vcolumn 
          where libname="WORK" and memname="_TMPIN") b on (upcase(a.name)=upcase(b.name))
   order by RULE;

   drop view work._tmpIn;
quit;
%mend;  /* check_reference_data */
