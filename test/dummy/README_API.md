# Rails API Base - Test Dummy App

This is a test Rails application demonstrating the `rails_api_base` gem usage.

## Setup

```bash
cd test/dummy
bundle install
bundle exec rails db:migrate
bundle exec rails db:seed
```

## Start Server

```bash
bundle exec rails server
```

## API Endpoints

### Posts API

#### List all posts (with pagination)
```bash
curl "http://localhost:3000/api/posts?page=1&size=10"
```

#### List posts with field selection
```bash
curl "http://localhost:3000/api/posts?fields=id,title,user"
```

#### Sort posts
```bash
curl "http://localhost:3000/api/posts?sort=-created_at"
```

#### Search posts
```bash
curl "http://localhost:3000/api/posts?q=Hello"
```

#### Filter posts
```bash
# Filter by status
curl "http://localhost:3000/api/posts?filter[status][eq]=published"

# Filter by views (greater than)
curl "http://localhost:3000/api/posts?filter[views][gt]=50"

# Filter by user_id (in array)
curl "http://localhost:3000/api/posts?filter[user_id][in]=1,2"
```

#### Get single post
```bash
curl "http://localhost:3000/api/posts/1?fields=title,user,comments"
```

#### Create post
```bash
curl -X POST "http://localhost:3000/api/posts" \
  -H "Content-Type: application/json" \
  -d '{
    "post": {
      "title": "New Post",
      "content": "This is a new post",
      "status": "published",
      "views": 0,
      "user_id": 1
    }
  }'
```

#### Update post
```bash
curl -X PUT "http://localhost:3000/api/posts/1" \
  -H "Content-Type: application/json" \
  -d '{
    "post": {
      "title": "Updated Title"
    }
  }'
```

#### Delete post
```bash
curl -X DELETE "http://localhost:3000/api/posts/1"
```

### Users API

#### List users
```bash
curl "http://localhost:3000/api/users?page=1&size=10"
```

#### List users with posts
```bash
curl "http://localhost:3000/api/users?fields=id,name,email,posts"
```

#### Search users
```bash
curl "http://localhost:3000/api/users?q=Alice"
```

## Response Format

All responses follow the unified format:

```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "rows": [...],
    "total": 100
  }
}
```

Error responses:

```json
{
  "code": 422,
  "msg": "Validation failed",
  "errors": ["Title can't be blank"]
}
```

## Created Files

### Models
- `app/models/user.rb`
- `app/models/post.rb`

### Blueprints
- `app/blueprints/user_blueprint.rb`
- `app/blueprints/post_blueprint.rb`

### Controllers
- `app/controllers/api/application_controller.rb`
- `app/controllers/api/posts_controller.rb`
- `app/controllers/api/users_controller.rb`

### Migrations
- `db/migrate/20250214000001_create_posts.rb`
- `db/migrate/20250214000002_create_users.rb`

### Routes
- `config/routes.rb`

## Test Data

Seeds created:
- 2 users (Alice, Bob)
- 4 posts (various statuses)
