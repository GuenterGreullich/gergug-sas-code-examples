options sastrace=',,,d' sastraceloc=saslog nostsuffix;

proc sql noerrorstop;
connect to duckdb as x1(file_path="az://pgtestcontainer"
   azure_blob_Endpoint='https://pgadls.blob.core.windows.net'
   azure_accountName='pgadls'
   azure_sas='****'
);
execute (SELECT version() AS version) by x1;
disconnect from x1;