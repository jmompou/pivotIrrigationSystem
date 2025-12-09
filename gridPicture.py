import matplotlib.pyplot as plt
import matplotlib.image as mpimg

# Load the map of the settlement
img = mpimg.imread('Medidasv3.png')

# Create a figure and an axis 
fig, ax = plt.subplots()

# Show the image on the axis
ax.imshow(img)

# Add a 2D grid to manually find the points
ax.grid(True)

# Set the axis limits to match the image dimensions 
ax.set_xlim(0, img.shape[1])
ax.set_ylim(img.shape[0], 0)

# Define the event handler to get the coordinates of a clicked point
def onclick(event):
    x = event.xdata
    y = event.ydata
    if x is not None and y is not None:
        print(f"Point clicked at ({x:.2f}, {y:.2f})")

# Connect the event handler to the plot
cid = fig.canvas.mpl_connect('button_press_event', onclick)

# Display the plot
plt.show()

