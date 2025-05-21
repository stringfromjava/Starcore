import json

path = input('enter the path to the aseprite .json file (dont include the extension): ')
print('(NOTE: the output file will be put in the same location that your original file came from)')
sprite_name = path.split('\\')[len(path.split('\\')) - 1]
aseprite_file = open(path.strip() + '.json', 'r')
output_file = open(path + '.xml', 'w')

data: dict = json.loads(aseprite_file.read())
output_data = '<?xml version=\'1.0\' encoding=\'utf-8\'?>\n'
output_data += '<TextureAtlas imagePath="' + sprite_name + '.png">\n'

for s in data['meta']['slices']:
    output_data += '    <SubTexture name="' + s['name'] + '_0" '  # texture name
    output_data += 'x="' + str(s['keys'][0]['bounds']['x']) + '" ' # x position
    output_data += 'y="' + str(s['keys'][0]['bounds']['y']) + '" ' # y position
    output_data += 'width="' + str(s['keys'][0]['bounds']['w']) + '" '  # graphic width
    output_data += 'height="' + str(s['keys'][0]['bounds']['h']) + '" '  # graphic height
    output_data += 'frameX="0" frameY="0" '
    output_data += 'frameWidth="' + str(data['frames'][sprite_name + '.']['sourceSize']['w']) + '" '  # image width
    output_data += 'frameHeight="' + str(data['frames'][sprite_name + '.']['sourceSize']['h']) + '" />\n'  # image height
    
output_data += '</TextureAtlas>'
output_file.write(output_data)
output_file.close()
aseprite_file.close()
