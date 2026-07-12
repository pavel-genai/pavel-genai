# papyrus (port 3000): serves HTML rendered from the bundled
# content/ directory (getting-started, typescript-tips,
# building-apis-with-express).

GET http://localhost:3000/health
HTTP 200
[Asserts]
jsonpath "$.status" == "ok"
jsonpath "$.service" == "papyrus"

# root redirects to the post list
GET http://localhost:3000/
HTTP 302
[Asserts]
header "Location" == "/posts"

GET http://localhost:3000/posts
HTTP 200
[Asserts]
header "Content-Type" contains "text/html"
body contains "Getting Started with Markdown CMS"
body contains "TypeScript Tips for Node.js Developers"

GET http://localhost:3000/posts/getting-started
HTTP 200
[Asserts]
body contains "Getting Started with Markdown CMS"

GET http://localhost:3000/posts/does-not-exist
HTTP 404
[Asserts]
body contains "Post not found"

GET http://localhost:3000/search?q=typescript
HTTP 200
[Asserts]
body contains "TypeScript Tips for Node.js Developers"

GET http://localhost:3000/tags/nodejs
HTTP 200
[Asserts]
body contains "Building REST APIs with Express"

# blank search query renders an empty result page, not an error
GET http://localhost:3000/search?q=
HTTP 200
[Asserts]
body contains "Search results for"

# unknown tag renders an empty list page
GET http://localhost:3000/tags/hurl-no-such-tag
HTTP 200
[Asserts]
body contains "Posts tagged"
body not contains "Getting Started with Markdown CMS"

# unknown routes hit the Express default 404
GET http://localhost:3000/definitely-not-a-route
HTTP 404
