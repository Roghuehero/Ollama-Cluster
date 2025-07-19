#!/usr/bin/env python3
import asyncio
import aiohttp
import json
import time
import sys
from datetime import datetime

class OllamaLoadTester:
    def __init__(self, base_url, concurrent_users=10, requests_per_user=5):
        self.base_url = base_url
        self.concurrent_users = concurrent_users
        self.requests_per_user = requests_per_user
        self.response_times = []
        self.errors = []
        
    async def send_request(self, session, user_id, request_id):
        start_time = time.time()
        try:
            payload = {
                "model": "gemma2:9b",
                "prompt": f"User {user_id} Request {request_id}: Explain machine learning in simple terms.",
                "stream": False
            }
            
            async with session.post(
                f"{self.base_url}/api/generate",
                json=payload,
                timeout=aiohttp.ClientTimeout(total=300)
            ) as response:
                if response.status == 200:
                    result = await response.json()
                    end_time = time.time()
                    response_time = end_time - start_time
                    self.response_times.append(response_time)
                    print(f"✅ User {user_id} Request {request_id}: {response_time:.2f}s")
                    return response_time
                else:
                    error_msg = f"HTTP {response.status} for User {user_id} Request {request_id}"
                    self.errors.append(error_msg)
                    print(f"❌ {error_msg}")
                    return None
                    
        except Exception as e:
            error_msg = f"User {user_id} Request {request_id}: {str(e)}"
            self.errors.append(error_msg)
            print(f"❌ Error - {error_msg}")
            return None
            
    async def simulate_user(self, user_id):
        connector = aiohttp.TCPConnector(limit=100)
        async with aiohttp.ClientSession(connector=connector) as session:
            tasks = []
            for request_id in range(self.requests_per_user):
                task = self.send_request(session, user_id, request_id)
                tasks.append(task)
                # Stagger requests slightly
                await asyncio.sleep(0.1)
            await asyncio.gather(*tasks, return_exceptions=True)
            
    async def run_load_test(self):
        print(f"🚀 Starting load test with {self.concurrent_users} users, {self.requests_per_user} requests each")
        print(f"📊 Total requests: {self.concurrent_users * self.requests_per_user}")
        print(f"🎯 Target URL: {self.base_url}")
        print(f"⏰ Started at: {datetime.now()}")
        
        start_time = time.time()
        
        # Create user tasks
        user_tasks = []
        for user_id in range(self.concurrent_users):
            user_task = self.simulate_user(user_id)
            user_tasks.append(user_task)
            
        # Run all user simulations concurrently
        await asyncio.gather(*user_tasks, return_exceptions=True)
        
        total_time = time.time() - start_time
        
        # Calculate statistics
        successful_requests = len(self.response_times)
        total_requests = self.concurrent_users * self.requests_per_user
        error_rate = len(self.errors) / total_requests * 100
        
        print(f"\n📈 Load Test Results:")
        print(f"⏱️  Total time: {total_time:.2f} seconds")
        print(f"✅ Successful requests: {successful_requests}/{total_requests}")
        print(f"❌ Error rate: {error_rate:.1f}%")
        
        if self.response_times:
            avg_response_time = sum(self.response_times) / len(self.response_times)
            min_response_time = min(self.response_times)
            max_response_time = max(self.response_times)
            
            # Calculate percentiles
            sorted_times = sorted(self.response_times)
            p50 = sorted_times[int(0.50 * len(sorted_times))]
            p95 = sorted_times[int(0.95 * len(sorted_times))]
            p99 = sorted_times[int(0.99 * len(sorted_times))]
            
            print(f"📊 Response Times:")
            print(f"   Average: {avg_response_time:.2f}s")
            print(f"   Minimum: {min_response_time:.2f}s")
            print(f"   Maximum: {max_response_time:.2f}s")
            print(f"   50th percentile: {p50:.2f}s")
            print(f"   95th percentile: {p95:.2f}s")
            print(f"   99th percentile: {p99:.2f}s")
            print(f"🚀 Throughput: {successful_requests / total_time:.2f} requests/second")
        
        if self.errors:
            print(f"\n❌ Errors encountered:")
            for error in self.errors[:10]:  # Show first 10 errors
                print(f"   {error}")
            if len(self.errors) > 10:
                print(f"   ... and {len(self.errors) - 10} more errors")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 load-test.py <ollama-url> [concurrent_users] [requests_per_user]")
        print("Example: python3 load-test.py https://ollama-api.yourdomain.com 20 5")
        sys.exit(1)
    
    base_url = sys.argv[1]
    concurrent_users = int(sys.argv[2]) if len(sys.argv) > 2 else 10
    requests_per_user = int(sys.argv[3]) if len(sys.argv) > 3 else 5
    
    tester = OllamaLoadTester(
        base_url=base_url,
        concurrent_users=concurrent_users,
        requests_per_user=requests_per_user
    )
    
    asyncio.run(tester.run_load_test())
