# openfood/urls.py
from django.urls import path
from . import views

urlpatterns = [
    path('product/<str:barcode>/', views.fetch_openfood_data, name='get_product_info'),
    path('api/signup/', views.signup, name='signup'),
    path('api/signin/', views.signin, name='signin'),
    path('api/user_allergens/', views.allergens, name='allergens_info'),
]
