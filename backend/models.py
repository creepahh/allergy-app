from django.db import models
from django.contrib.auth.models import User
import json
from django.utils.timezone import now

class Allergens(models.Model):
    allergens_name = models.CharField( max_length=100)

    def set_allergens(self, allergens_list):
        self.allergens = ",".join(allergens_list)

    def get_allergens(self):
        if self.allergens:
            return self.allergens.split(",")
        return []

    def __str__(self):
        return self.allergens_name

class UserAllergy(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    allergen = models.ManyToManyField(Allergens)


    def __str__(self):  
        return self.user.username 


class Product(models.Model):
    name = models.CharField(max_length=255)
    code = models.CharField(max_length=20, unique=True)
    ingredients = models.TextField(blank=True, null=True)
    nutrition_grade = models.CharField(max_length=1, blank=True, null=True),
    ingredients = models.TextField(blank=True, null=True)
    brand = models.CharField(max_length=50),
    status = models.BooleanField(default=False)
    allergens = models.ManyToManyField(Allergens)
    user = models.OneToOneField(User, on_delete=models.CASCADE, default=1)
    created_at = models.DateTimeField(default=now, editable=False)
    # image_url = models.URLField(blank=True, null=True)
    

    def __str__(self):
        return self.name

    def get_nutrition(self):
        return json.loads(self.nutrition)

    def set_nutrition(self, nutrition_data):
        self.nutrition = json.dumps(nutrition_data)
