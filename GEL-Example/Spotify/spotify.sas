/** https://sww2.sas.com/blogs/wp/gate/156976/analyzing-spotifys-most-streamed-songs-insights-from-data-exploration-and-modeling-in-sas-studio/demcko/2026/02/23 **/

/* Today, artists reach listeners primarily through music streaming services such as Spotify, Apple Music, and Deezer. In this analysis, we examine the most streamed songs 
   and explore key factors that may contribute to an artist’s success across these platforms. The dataset includes 952 songs and approximately 24 variables, including track 
   and artist names, release date information, stream counts, playlist placements, and chart rankings. */

/* Loading Data into the SAS Environment */

/*******  Import the Spotify 20243 Songs Dataset  *******/
 
libname SP '/export/pvs/sasdata/homes/gergug/gergug-sas-code-examples/gergug-sas-code-examples/GEL-Example/Spotify';
 
libname out '/export/pvs/sasdata/homes/gergug/gergug-sas-code-examples/gergug-sas-code-examples/GEL-Example/Spotify/output';
/* Start CAS Session */;
cas;
caslib _all_ assign;
 
proc import
      datafile="/export/pvs/sasdata/homes/gergug/gergug-sas-code-examples/gergug-sas-code-examples/GEL-Example/Spotify/spotify-2023.csv"
      out=out.Spotify_data dbms=csv replace;
      getnames=yes;
run;

proc print data=out.spotify_data (obs=5);
run;

/*  
    Data Exploration
    
    We use the PROC MEANS procedure to calculate descriptive statistics, including the mean, median, minimum, maximum, and the number of missing values in the dataset.
*/

proc means data=out.spotify_data mean median min max nmiss;
 
    var streams in_spotify_playlists in_spotify_charts
 
        in_apple_playlists in_apple_charts
 
        in_deezer_playlists in_deezer_charts;
 
run;

/****** Streams by Release Year*******/
 
proc sgplot data=out.spotify_clean;
 
    vbar released_year / response=streams stat=sum
 
    datalabel seglabel;
 
    title "Total Streams by Release Year";
 
run;

proc freq data=out.spotify_data;
 
    tables released_year released_month released_day;
 
run;

/*********CLEAN THE DATA AND HANDLE MISSING VALUES **********/
 
data out.spotify_clean;
 
    set out.spotify_data;
 
    /***** Change the columns for comma delimiter ****/
 
    format in_spotify_playlists comma16. streams comma16.;
 
    /*****DROPPING ROWS WITH MISSING DATA****/
 
    if nmiss(of _numeric_) &gt; 0 then delete;
 
    /*********Set Numeric Misses to 0 when missing the value*********/
 
    array numvars[*] streams in_spotify_playlists in_spotify_charts
 
        in_apple_playlists in_apple_charts in_deezer_playlists in_deezer_charts;
 
    do i=1 to dim(numvars);
 
        if missing(numvars[i]) then numvars[i]=0;
 
    end;
 
    drop i;
 
run;

proc sort data=out.spotify_clean out=out.top_streams;
 
    by descending streams;
 
    /*******  Top 25 Stream   *******/
 
    proc print data=out.top_streams (obs=25);
 
        var track_name artist_name streams;
 
        title "Top 25 Most Streamed Spotify Songs of 2023";
 
    run;

/* Artist with Most Streams */

    proc print data=out.artist_streams(obs=10);
 
    var artist_name total_streams;
 
    format total_streams comma16.;
 
    title "Top 10 Artists by Aggregate Streams";
 
run;

proc corr data=out.spotify_clean;
 
    var streams energy danceability
 
        in_spotify_playlists in_spotify_charts
 
        in_apple_playlists in_apple_charts
 
        in_deezer_playlists in_deezer_charts
 
        valence acousticness instrumentalness liveness speechiness;
 