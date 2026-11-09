from django.http import HttpResponse
from rest_framework.decorators import api_view
from rest_framework.response import Response


# Create your views here.
def home(request):
    return HttpResponse("<h1>Hello World!</h1><p>Welcome to the home page of our Django application.</p>")

def about(request):
    return HttpResponse("<h1>This is the About Page.</h1><p>This is the about page of our application.</p>")


@api_view(['GET'])
def hello_api(request):
    """Return a public greeting through the REST API."""
    return Response({"message": "Hello World!"})
