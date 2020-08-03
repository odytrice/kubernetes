from dask_gateway import Gateway

gateway = Gateway(
    address = "http://dask.domain.com",
    asynchronous = False,
    loop = None
)

gateway.auth.password = '<password>'

# clusters = gateway.list_clusters()

# for cluster in clusters:
#     gateway.stop_cluster(cluster.name)
#     print(cluster.name)


cluster = gateway.new_cluster()

# cluster.scale(2)

client = cluster.get_client()


import dask.array as da

x = da.random.normal(size = (5000, 5000), chunks = 1000)

x.dot(x.T).sum(axis=1).compute()




cluster.shutdown()

gateway.close()