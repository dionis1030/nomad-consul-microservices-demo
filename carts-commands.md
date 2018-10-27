# Interacting with Carts application without front-end

These commands allow you to interact with the carts application from the Nomad client to which it is deployed.

It uses the following 3 data files which will automatically be copied to the client.

item1.json:
{
  "itemId":"1",
  "quantity": 1,
  "unitPrice" : 17.55
  }
}

item2.json:
{
  "itemId":"2",
  "quantity": 2,
  "unitPrice" : 12.95
}

item3.json:
{
  "itemId":"3",
  "quantity": 1,
  "unitPrice" : 42.99
}

Run these curl commands on the Nomad client to inject items into the cart for customer 1:
```
curl -H "Content-Type: application/json" --data @item1.json  http://carts/carts/1/items

curl -H "Content-Type: application/json" --data @item2.json http://carts/carts/1/items

curl -H "Content-Type: application/json" --data @item3.json http://carts/carts/1/items
```

Use this command to see the contents of the cart:
`curl -H "Content-Type: application/json" http://carts/carts/1/items | jq`

Use this command to remove item 3 from the cart:
`curl -H "Content-Type: application/json" -X DELETE http://carts/carts/1/items/3`

Use this command to delete the entire cart:
`curl -H "Content-Type: application/json" -X DELETE http://carts/carts/1`
