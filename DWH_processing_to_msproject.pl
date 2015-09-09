use DBI;

  #@driver_names = DBI->available_drivers;
  #%drivers      = DBI->installed_drivers;
  #@data_sources = DBI->data_sources($driver_name, \%attr);

$batch_load_id=913;
$statement = " SELECT a.job_process_id,
       a.job_name,
       a.job_status_time - a.job_start_time duration,
       a.job_start_time,
       a.job_status_time,
       c.job_process_id predecessor,
       row_number() over (partition by a.job_process_id order by a.job_process_id) rn  
  FROM 
      ctrl.ctrl_batch_jobs a 
      LEFT OUTER JOIN ctrl.ctrl_job_dependencies b ON (a.job_name = b.dependant_job_name)
      LEFT OUTER JOIN
           (SELECT job_process_id,
                   job_name
              FROM ctrl.ctrl_batch_jobs
             WHERE batch_load_id = $batch_load_id) c ON (b.job_name = c.job_name)
 WHERE batch_load_id = $batch_load_id";

$data_source="EDWP01";
$username="admin";
$auth="xxxxxx";

  $dbh = DBI->connect($data_source, $username, $auth, \%attr);

  $rv  = $dbh->do($statement);
  $rv  = $dbh->do($statement, \%attr);
  $rv  = $dbh->do($statement, \%attr, @bind_values);

  $ary_ref  = $dbh->selectall_arrayref($statement);
  $hash_ref = $dbh->selectall_hashref($statement, $key_field);

  $ary_ref  = $dbh->selectcol_arrayref($statement);
  $ary_ref  = $dbh->selectcol_arrayref($statement, \%attr);

  @row_ary  = $dbh->selectrow_array($statement);
  $ary_ref  = $dbh->selectrow_arrayref($statement);
  $hash_ref = $dbh->selectrow_hashref($statement);

  $sth = $dbh->prepare($statement);
  $sth = $dbh->prepare_cached($statement);

  $rc = $sth->bind_param($p_num, $bind_value);
  $rc = $sth->bind_param($p_num, $bind_value, $bind_type);
  $rc = $sth->bind_param($p_num, $bind_value, \%attr);

  $rv = $sth->execute;
  $rv = $sth->execute(@bind_values);
  $rv = $sth->execute_array(\%attr, ...);

  $rc = $sth->bind_col($col_num, \$col_variable);
  $rc = $sth->bind_columns(@list_of_refs_to_vars_to_bind);

  @row_ary  = $sth->fetchrow_array;
  $ary_ref  = $sth->fetchrow_arrayref;
  $hash_ref = $sth->fetchrow_hashref;

  $ary_ref  = $sth->fetchall_arrayref;
  $ary_ref  = $sth->fetchall_arrayref( $slice, $max_rows );

  $hash_ref = $sth->fetchall_hashref( $key_field );

  $rv  = $sth->rows;

  $rc  = $dbh->begin_work;
  $rc  = $dbh->commit;
  $rc  = $dbh->rollback;

  $quoted_string = $dbh->quote($string);

  $rc  = $h->err;
  $str = $h->errstr;
  $rv  = $h->state;

  $rc  = $dbh->disconnect;