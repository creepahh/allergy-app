from rest_framework import serializers
from .models import Product, UserAllergy,Allergens

class ProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = '__all__'


class AllergensSerializer(serializers.ModelSerializer):
    class Meta:
        model = Allergens
        fields = ['allergens_name']

class UserAllergySerializer(serializers.ModelSerializer):
    user_email = serializers.EmailField(source='user.email', read_only=True)
    allergens = AllergensSerializer(many=True, read_only=True, source='allergen')

    class Meta:
        model = UserAllergy
        fields = ['user_email', 'allergens']

