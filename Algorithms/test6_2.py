V = int(input())
E = int(input())

adj_list = [[] for _ in range(V)]

for _ in range(E):
    s, e = map(int, input().split())
    adj_list[s].append(e)
    
print(adj_list)