export default function beforeUnload(old_props){
  // 如果页面有改动后, 刷新改页面或者关闭页面, 会弹出"您的信息将不会被保存"
  $(window).bind("beforeunload", function(){
    let has_changed = false;
    console.log(old_props.fields);
    for(let field in old_props.fields){
      if($(`[name="${field}"]`).prop("tagName") != 'INPUT'){
        continue;
      }
      if(old_props[field] == $(`[name="${field}"]`).val()){
        continue;
      }

      if(old_props[field] == undefined && $(`[name="${field}"]`).val() == ""){
        continue
      }

      if($(`[name="${field}"]`).val() == $(`[name="${field}"]`).attr("value")){
        continue;
      }

      if($(`[name="${field}"]`).val() == "" &&  $(`[name="${field}"]`).attr("value") == undefined){
        continue;
      }

      has_changed = true
      break;
    }

    if(has_changed) return "您的信息将不会被保存";
  });
}