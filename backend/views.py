# openfood/views.py
from rest_framework.decorators import api_view, renderer_classes
from django.contrib.auth import authenticate, login  
from rest_framework.response import Response
import requests
from django.views.decorators.csrf import csrf_exempt
import json
from django.http import JsonResponse
from . import models

from django.contrib.auth.models import User

from django.contrib.auth.decorators import login_required

from .serializers import ProductSerializer, UserAllergySerializer
from django.shortcuts import get_object_or_404
from rest_framework.renderers import JSONRenderer

import random


@api_view(['GET'])
def fetch_openfood_data(request, barcode):
    # Make a GET request to the Open Food Facts API
    api_url = f'https://world.openfoodfacts.net/api/v2/product/{barcode}.json'
    response = requests.get(api_url)

    if response.status_code == 200:
        ## Return the JSON response
        response_json = response.json()
        ##clean
        bar_code = response_json.get("code")
        allergens = response_json.get("allergens")
        allergens_from_ingredients = response_json.get("allergens_from_ingredients")
        allergens_hierarchy = response_json.get("allergens_hierarchy")
        brands = response_json.get("brands")
        ingredients = response_json.get("ingredients")
        ingredients_analysis = response_json.get("ingredients_analysis")
        ingredients_hierarchy = response_json.get("ingredients_hierarchy")
        nutrient_levels =response_json.get("nutrient_levels")

        return Response(f'{bar_code},{allergens}')
    else:
        return Response({'error': 'Failed to fetch data from Open Food Facts API'}, status=response.status_code)

@api_view(['GET'])
def user_products_by_email(request, email):
    user = get_object_or_404(User, email=email)
    user_products = models.Product.objects.filter(user=user).order_by('-created_at')[:10]
    serializer = ProductSerializer(user_products, many=True)
    return Response(serializer.data)  

@csrf_exempt
def signup(request):
    if request.method == 'POST':
        data = json.loads(request.body.decode('utf-8'))
        email = data.get('email')
        full_name = data.get('full_name')
        password = data.get('password')
        
        random_integer = random.randint(1000, 9999) 
        
        username = f"{full_name.replace(' ', '_')}{random_integer}"
        
        register_user = User.objects.create_user(
                first_name= full_name , last_name="testcase", email=email, password=password, username=username)
        

        return JsonResponse({'message': 'User registered successfully'}, status=201)
    else:
        return JsonResponse({'error': 'Invalid request method'}, status=400)

@csrf_exempt
def signin(request):
    if request.method == 'POST':
        data = json.loads(request.body.decode('utf-8'))
        email = data.get('email')
        password = data.get('password')
        
        user = authenticate(request, email=email, password=password)
        
        if user is not None:

            return JsonResponse({'message': 'User loggedin successfully'}, status=201)
        else:
            return JsonResponse({'message': 'wrong crendentials'}, status=401)
    else:
        return JsonResponse({'error': 'Invalid request method'}, status=400)

@csrf_exempt
def allergens(request):
    if request.method == 'POST':
        data = json.loads(request.body.decode('utf-8'))
        email = data.get('email')
        print(data)
        allergen_names = data.get('allergies')
        print(allergen_names)

        user = get_object_or_404(User, email=email)

        user_allergy, created = models.UserAllergy.objects.get_or_create(user=user)
        allergens = [models.Allergens.objects.get_or_create(allergens_name=name)[0] for name in allergen_names]
        user_allergy.allergen.set(allergens)
        

        return JsonResponse({'message': 'allergens detail received succesfully'}, status=201)
    else:
        return JsonResponse({'error': 'some error occured'}, status=400)

@api_view(['POST'])
@renderer_classes([JSONRenderer])  # Explicitly set the renderer
def get_user_detail(request):
    if request.method == 'POST':
        data = json.loads(request.body.decode('utf-8'))
        email = data.get('email')

        try:
            user_allergy = models.UserAllergy.objects.get(user__email=email)
            serializer = UserAllergySerializer(user_allergy)
            return Response(serializer.data, status=201)
        except models.UserAllergy.DoesNotExist:
            return JsonResponse({'error': 'User allergy information not found for the given email'}, status=404)
        
    else:
        return JsonResponse({'error': 'Invalid request method'}, status=400)