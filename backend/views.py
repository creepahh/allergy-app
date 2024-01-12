# openfood/views.py
from rest_framework.decorators import api_view
from django.contrib.auth import authenticate, login  
from rest_framework.response import Response
import requests
from django.views.decorators.csrf import csrf_exempt
import json
from django.http import JsonResponse
from . import models

from django.contrib.auth.models import User

from django.contrib.auth.decorators import login_required

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
        

        return JsonResponse({'message': 'allergens detail received succesfully'}, status=201)
    else:
        return JsonResponse({'error': 'some error occured'}, status=400)