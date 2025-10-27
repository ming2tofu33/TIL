V = int(input())
E = int(input())

adj_matrix = [[0] * V for _ in range(V)]

for _ in range(E):
    s, e = map(int, input().split())
    adj_matrix[s][e] = 1
    
print(adj_matrix)