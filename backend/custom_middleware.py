from django.conf import settings
from django.contrib.auth.backends import ModelBackend
from .custom_auth_backend import EmailBackend

class AdminAuthMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if request.path.startswith('/admin/'):
            # Use Django's default authentication backend for admin
            settings.AUTHENTICATION_BACKENDS = ['django.contrib.auth.backends.ModelBackend']
        else:
            # Use your custom authentication backend for other views
            settings.AUTHENTICATION_BACKENDS = ['backend.custom_auth_backend.EmailBackend']
        response = self.get_response(request)
        return response
