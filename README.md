# dashdns
### Build
    bundle install
    warble
### Run
    java -jar dashdns.jar example.net
    
### Test
    dig 10-58-21-42.example.net @127.0.0.1 -p 5300
    
Should return an A record with a 1 day TTL for 10.58.21.42
  