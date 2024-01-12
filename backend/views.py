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


@api_view(['POST'])
def fetch_openfood_data(request):
    if request.method == 'POST':
        # Check if request body is empty
        if not request.body:
            return JsonResponse({'error': 'Empty request body'}, status=400)

        # Try to parse JSON data from the request body
        try:
            data = json.loads(request.body.decode('utf-8'))
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON'}, status=400)

        # Extract barcode and check if it's provided
        barcode = data.get('barcode')
        loggedin_email = data.get('email')
        if not barcode:
            return JsonResponse({'error': 'Barcode is required'}, status=400)

        api_url = f'https://world.openfoodfacts.net/api/v2/product/{barcode}.json'

        # Make the external API request
        try:
            user = User.objects.get(email=loggedin_email)
            user_allergy = models.UserAllergy.objects.get(user=user)
            user_allergens_list = list(allergen.allergens_name for allergen in user_allergy.allergen.all())
            print(loggedin_email)
            print(user_allergens_list)
            response = requests.get(api_url)
        except requests.RequestException as e:
            return JsonResponse({'error': str(e)}, status=500)

        # Check if the response from the external API is successful
        if response.status_code == 200:
            response_json = response.json()
            product_data = response_json.get("product", {})

            allergens_hierarchy_cleaned = [allergen.split(":")[1] if ":" in allergen else allergen for allergen in product_data.get("allergens_hierarchy")]
            print(allergens_hierarchy_cleaned)
            #find common allergens from user and scanned food
            common_allergens = list(set(user_allergens_list) & set(allergens_hierarchy_cleaned))
            result = {
                'barcode': product_data.get("code"),
                'allergens': allergens_hierarchy_cleaned,
                'brands': product_data.get("brands"),
                'ingredients': product_data.get("ingredients"),
                'ingredients_analysis': product_data.get("ingredients_analysis"),
                'ingredients_hierarchy': product_data.get("ingredients_hierarchy"),
                'nutrient_levels': product_data.get("nutrient_levels"),
                'hasAllergen': bool(common_allergens := list(set(user_allergens_list) & set(allergens_hierarchy_cleaned)))
            }

            return JsonResponse({'allergens_list': common_allergens,'all_results':result}, status=200)
        else:
            return JsonResponse({'error': 'Failed to fetch data from Open Food Facts API'}, status=response.status_code)
    else:
        return JsonResponse({'error': 'Invalid request method'}, status=400)