 bundle exec htmlproofer _site \
    \-\-disable-external=true \
    \-\-ignore-urls "/^http:\/\/127.0.0.1/,/^http:\/\/0.0.0.0/,/^http:\/\/localhost/"
