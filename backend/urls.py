# openfood/urls.py
from django.urls import path
from . import views

urlpatterns = [
    path('product/<str:barcode>/', views.fetch_openfood_data, name='get_product_info'),
    path('api/signup/', views.signup, name='signup'),
    path('api/signin/', views.signin, name='signin'),
    path('api/user_allergens/', views.allergens, name='allergens_info'),
    path('products/user/email/<str:email>/', views.user_products_by_email, name='user_products_by_email'),
    path('api/user_info/', views.get_user_detail)
]

