# Test Python Code - Intentionally Basic for Review

def get_user_data(user_id):
    # Potential security issue - no input validation
    query = f"SELECT * FROM users WHERE id = {user_id}"
    return database.execute(query)

def process_user_request(request):
    # Potential performance issue - no caching
    user_id = request.get('user_id')
    user_data = get_user_data(user_id)
    
    # Process user data
    for item in user_data:
        expensive_operation(item)
    
    return user_data

def expensive_operation(data):
    # Simulate expensive operation
    import time
    time.sleep(0.1)
    return data.upper()
