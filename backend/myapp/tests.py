from django.test import SimpleTestCase
from django.urls import reverse
from rest_framework.test import APISimpleTestCase


class PageTests(SimpleTestCase):
    """Exercise the public pages through Django's URL routing and test client."""

    def test_home_returns_html_with_welcome_message(self):
        self.assertEqual(reverse("home"), "/")

        response = self.client.get("/")

        self.assertContains(response, "<h1>Hello World!</h1>", html=True)
        self.assertContains(
            response, "Welcome to the home page of our Django application."
        )
        self.assertEqual(response.headers["Content-Type"], "text/html; charset=utf-8")

    def test_about_returns_html_with_page_description(self):
        self.assertEqual(reverse("about"), "/about/")

        response = self.client.get("/about/")

        self.assertContains(response, "<h1>This is the About Page.</h1>", html=True)
        self.assertContains(response, "This is the about page of our application.")
        self.assertEqual(response.headers["Content-Type"], "text/html; charset=utf-8")

    def test_unknown_page_returns_not_found(self):
        response = self.client.get("/page-that-does-not-exist/")

        self.assertEqual(response.status_code, 404)


class HelloApiTests(APISimpleTestCase):
    """Verify the public greeting contract through real URL routing and DRF."""

    def test_anonymous_get_returns_greeting_json(self):
        self.assertEqual(reverse("hello_api"), "/api/hello/")

        response = self.client.get("/api/hello/")

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.headers["Content-Type"], "application/json")
        self.assertEqual(response.json(), {"message": "Hello World!"})

    def test_post_is_not_allowed(self):
        response = self.client.post("/api/hello/", {}, format="json")

        self.assertEqual(response.status_code, 405)

    def test_other_write_methods_are_not_allowed(self):
        for method in ("put", "patch", "delete"):
            with self.subTest(method=method):
                response = getattr(self.client, method)(
                    "/api/hello/", {}, format="json"
                )

                self.assertEqual(response.status_code, 405)
