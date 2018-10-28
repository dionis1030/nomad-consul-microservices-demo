# Interacting with catalogue application without front-end

These commands allow you to interact with the catalogue application from the Nomad server or the Nomad client to which it was deployed.

Use this command to see the contents of the catalogue:
`curl -H "Content-Type: application/json" http://catalogue/catalogue | jq`

Use this command to see the "colourful" socks from the catalogue:
`curl -H "Content-Type: application/json" http://catalogue/catalogue/3395a43e-2d88-40de-b95f-e00e1502085b | jq`
