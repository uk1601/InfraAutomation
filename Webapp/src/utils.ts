class Utils {
    public static filterNonNullValues = (obj:any) => {
        const filteredObj:any = {};
    
        for (const [key, value] of Object.entries(obj)) {
            if (value !== null) {
                filteredObj[key] = value;
            }
        }
    
        return filteredObj;
    }
}
export default Utils;
