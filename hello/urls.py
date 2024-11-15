from django.urls import path

from .views import hello_team

urlpatterns = [
    path("", hello_team),
]
