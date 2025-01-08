
The google api key has to be saved into the env variable $GOOGLE_API_KEY
or passed as an argument to the call with the option -a or --api_key

```
lua convert.lua -a <your-google-api-key> youtube-playlist.csv
```
or, after setting the env variable
```
lua convert.lua youtube-playlist.csv
```

to generate the db file to import into FreeTube
```
lua convert.lua youtube-playlist.csv >> freetube-playlist.db 
```
