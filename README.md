
# A Dana Life - Source Code

Live site available here: [https://www.dana.lol](http://www.dana.lol)

```
   
                             mNNMMMMNNm
                      ./oydNMMMMMMMMMMMMNmho/.
                  `/ymMMMMMMMMMMMMMMMMMMMMMMMMNy/`.m:m.
                /hMMMMMMMNdyo/:--..--:/oydNMMMMMMMMMMMMMy.
             `oNMMMMMNy/.                  ./yNMMMMMMMMMMM:
            +NMMMMMy:                         yMMMMMMMMMMMh
          -mMMMMNo`                           oMMMMMMMMMMMs
         +MMMMMy`                              sMMMMMMMMMMo
        oMMMMN:                                 .ohmmmNMMMMs
       +MMMMN.                                        .mMMMMo
      -MMMMN.                  .://:.                  .NMMMM:
      hMMMM+                /hNMMMMMMMh/                /MMMMm:
     sMMMMm               -mMMMMMMMMMMMMm:               dMMMMs
     mMMMMo              .NMMMMMMMMMMMMMMM-              +MMMMm
     MMMMM/              yMMMMMMMMMMMMMMMMh              :MMMMM
     MMMMM/              yMMMMMMMMMMMMMMMMh              :MMMMM
     mMMMMo              -MMMMMMMMMMMMMMMM-              +MMMMm
     sMMMMm               -mMMMMMMMMMMMMN:               dMMMMs
      dMMMM/                /hMMMMMMMMd+`               :MMMMm/
      -MMMMN.                  -://:-                  .NMMMM:
       +MMMMm.                                        `mMMMMs
        oMMMMN:                                      -NMMMMy
         +MMMMMs`                                  `sMMMMMo
          -mMMMMNo`                              `+NMMMMm:
            oNMMMMNy:                          -sNMMMMNo`
             `oNMMMMMNy/.                  ./yNMMMMMNs`
                /hMMMMMMMNhs+/:-....-:/+shNMMMMMMMd/`
                  `/yNMMMMMMMMMMMMMMMMMMMMMMMMNy+`
                      ./shmMMMMMMMMMMMMMMmhs/.
                             mNNMMMMNNm
```

### Contact Form

The site is designed to be static, but there is a small app that runs [the contact page](https://www.dana.lol/contact). You can view the code that runs the contact page in the [`danalol-contact-form` project](https://github.com/dmerrick/danalol-contact-form).


### Technical Infrastructure

To build out the infrastructure required to run this site, you can use the CloudFormation templates found in `cloudformation/`

You will need domain name (like `example.com`), a blog domain name (like `www.example.com`), and an AWS ACM Certificate ARN string.
```
# create the hosted zone in Route53
aws cloudformation create-stack \
  --stack-name <<ROUTE53 STACK NAME>> \
  --template-body file://./cloudformation/route53-zone.yaml \
  --parameters ParameterKey=DomainName,ParameterValue=<<EXAMPLE.COM>>

# create the S3 bucket and CloudFront setup
aws cloudformation create-stack \
  --stack-name <<CDN STACK NAME>> \
  --template-body file://./cloudformation/s3-static-website-with-cloudfront-and-route-53.yaml \
  --parameters \
      ParameterKey=DomainName,ParameterValue=<<EXAMPLE.COM>> \
      ParameterKey=FullDomainName,ParameterValue=<<WWW.EXAMPLE.COM>> \
      ParameterKey=AcmCertificateArn,ParameterValue=<<ACM ARN STRING>>
```

