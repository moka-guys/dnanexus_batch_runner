import dxpy
import sys


def main():

    inputs_file = open("inputs_stats.txt", 'w')

    print sys.argv[2]

    workflow = dxpy.DXWorkflow(sys.argv[2].split(":")[-1])
    fh = dxpy.DXFile(sys.argv[1].split(":")[-1])

    if "/Results" in fh.describe()['folder']:
        return

    app_id = sys.argv[3]

    if "applet" in app_id:
        app = dxpy.DXApplet(app_id)
    else:
        app = dxpy.DXApp(app_id)

    w_id = sys.argv[1].split(":")[1]

    existing_inputs = []
    for item in workflow.describe()['stages'][0]['input']:
        existing_inputs.append(item)
    print existing_inputs

    for x in app.describe()['inputSpec']:
        print x
        if x['class'] == 'file' and x['name'] not in existing_inputs:
            inputs_file.write(x['name'] + "\n")
            
    inputs_file.close()

main()
