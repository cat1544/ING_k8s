from locust import HttpUser, TaskSet, between, task
import random

products = [
    {'product_id': '0PUK6V6EV0', 'image_url': "https://www.dev-boutique.shop/static/img/products/candle-holder.jpg"},
    {'product_id': '1YMWWN1N4O', 'image_url': "https://www.dev-boutique.shop/static/img/products/watch.jpg"},
    {'product_id': '2ZYFJ3GM2N', 'image_url': "https://www.dev-boutique.shop/static/img/products/hairdryer.jpg"},
    {'product_id': '66VCHSJNUP', 'image_url': "https://www.dev-boutique.shop/static/img/products/tank-top.jpg"},
    {'product_id': '6E92ZMYYFZ', 'image_url': "https://www.dev-boutique.shop/static/img/products/mug.jpg"},
    {'product_id': '9SIQT8TOJO', 'image_url': "https://www.dev-boutique.shop/static/img/products/bamboo-glass-jar.jpg"},
    {'product_id': 'L9ECAV7KIM', 'image_url': "https://www.dev-boutique.shop/static/img/products/loafers.jpg"},
    {'product_id': 'LS4PSXUNUM', 'image_url': "https://www.dev-boutique.shop/static/img/products/salt-and-pepper-shakers.jpg"},
    {'product_id': 'OLJCESPC7Z', 'image_url': "https://www.dev-boutique.shop/static/img/products/sunglasses.jpg"}
]

def index(l):
    l.client.get("/")
    l.client.get("https://www.dev-boutique.shop/static/img/products/candle-holder.jpg")
    l.client.get("https://www.dev-boutique.shop/static/img/products/watch.jpg")
    l.client.get("https://www.dev-boutique.shop/static/img/products/hairdryer.jpg")
    l.client.get("https://www.dev-boutique.shop/static/img/products/tank-top.jpg")
    l.client.get("https://www.dev-boutique.shop/static/img/products/mug.jpg")
    l.client.get("https://www.dev-boutique.shop/static/img/products/bamboo-glass-jar.jpg")
    l.client.get("https://www.dev-boutique.shop/static/img/products/loafers.jpg")
    l.client.get("https://www.dev-boutique.shop/static/img/products/salt-and-pepper-shakers.jpg")
    l.client.get("https://www.dev-boutique.shop/static/img/products/sunglasses.jpg")

def browseProduct(l):
    product = random.choice(products)
    l.client.get(f"/product/{product['product_id']}")
    l.client.get(product['image_url'])

def viewCart(l):
    l.client.get("/cart")

def addToCart(l):
    product = random.choice(products)
    l.client.get(f"/product/{product['product_id']}")
    l.client.post("/cart", {
        'product_id': product['product_id'],
        'quantity': random.choice([1, 2, 3, 4, 5, 10])
    })

def checkout(l):
    addToCart(l)
    l.client.post("/cart/checkout", {
        'email': 'someone@example.com',
        'street_address': '1600 Amphitheatre Parkway',
        'zip_code': '94043',
        'city': 'Mountain View',
        'state': 'CA',
        'country': 'United States',
        'credit_card_number': '4432-8015-6152-0454',
        'credit_card_expiration_month': '1',
        'credit_card_expiration_year': '2039',
        'credit_card_cvv': '672',
    })

class UserBehavior(TaskSet):

    def on_start(self):
        index(self)

    tasks = {index: 1,
        browseProduct: 10,
        addToCart: 2,
        viewCart: 3,
        checkout: 1}

class WebsiteUser(HttpUser):
    tasks = [UserBehavior]
    wait_time = between(1, 10)
