# Interacting with Carts application without front-end

Created item1.json:
{
  "itemId":"1",
  "quantity": 1,
  "unitPrice" : 17.55
  }
}

Created item2.json:
{
  "itemId":"2",
  "quantity": 2,
  "unitPrice" : 12.95
}

Created item3.json:
{
  "itemId":"3",
  "quantity": 1,
  "unitPrice" : 42.99
}

Used these curl commands to inject items into cart for customer 1:
```
curl --data @item1.json -H "Content-Type: application/json"  http://carts/carts/1/items

curl --data @item2.json -H "Content-Type: application/json"  http://carts/carts/1/items

curl --data @item3.json -H "Content-Type: application/json"  http://carts/carts/1/items
```

Use this command to see contents of cart:
`curl  -H "Content-Type: application/json"  http://carts/carts/1/items | jq`

Use this command to remove item 3 from cart:
`curl -X DELETE -H "Content-Type: application/json"  http://carts/carts/1/items/3`

Use this command to delete entire cart:
`curl -X DELETE -H "Content-Type: application/json"  http://carts/carts/1`
