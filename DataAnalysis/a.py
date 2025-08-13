from collections import deque


# list -> queue로 쓰고 시픙면 성ㅇ능이 떨어짐 -> 


# [a, b, c, d]


# d부터 나온다 : stack
# a부터 나온다 : queue


lst = [1, 2, 3]
q = deque([1, 2, 3])

lst.pop()
q.pop()


lst.pop(0)
q.popleft()


lst.append(10)
q.append(10)


lst.insert(0, 10)
q.appendleft(10)


import heapq

lst = [1, 24, 793, 53, 13, 2, 100, 32, 72, 825]

heapq.heapify(lst)

print(lst)
print(heapq.heappop(lst))
print(lst)
print(heapq.heappop(lst))
print(lst)
print(heapq.heappop(lst))
print(lst)