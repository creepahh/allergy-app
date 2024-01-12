# openfood/models.py
from django.db import models

class Product(models.Model):
    name = models.CharField(max_length=255)
    code = models.CharField(max_length=20, unique=True)
    description = models.TextField(blank=True, null=True)
    ingredients = models.TextField(blank=True, null=True)
    nutrition_grade = models.CharField(max_length=1, blank=True, null=True),
    allergens = models.TextField(blank=True, null=True)
    # image_url = models.URLField(blank=True, null=True)
    # Add other fields as needed

    def __str__(self):
        return self.name
