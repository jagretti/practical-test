from django.shortcuts import render
from django.http import HttpResponse

def hello_team(request):
    return HttpResponse("Hi Koronet team.")
