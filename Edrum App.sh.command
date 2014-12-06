#!/bin/bash
redis-server &
rails s &
sleep 3
open http://localhost:3000/