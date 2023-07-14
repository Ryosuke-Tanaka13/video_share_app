    import 'bootstrap';
    import '../stylesheets/questionnaires'; // This file will contain your custom CSS
    import "@fortawesome/fontawesome-free/js/all";
        
    const toggleFormBtn = document.getElementById("toggleFormBtn");

    toggleFormBtn.addEventListener ("click", () => {
    
        console.error()
        var i = 1 ;
        const myDiv = document.getElementById('mydiv');
        $(document).on("click", "#add_button", function(){
        var input_data = document.createElement('input');
        input_data.type = 'text';
        input_data.id = 'inputform' + i;
        input_data.placeholder = 'フォーム-' + i;
        var parent = document.getElementById('form_area');
        parent.appendChild(input_data);
        i++ ;
        })
    
        const checkbox = document.getElementById('switch');
        const formInputs = document.getElementById('from input[required]');

        let requiredOn = true;
        document.addEventListener('click', () => {
            requiredOn = !requiredOn;
            formInputs.forEach(input=> {
                input.required = requiredOn;
            });
           switchtextContent = requiredOn ? 'Switch Required Off' : 'Switch Required On';
           const title = document.querySelector('.title');
           title.textContent = checkbox.checked ? 'ON' : 'OFF';
        });
  
        $(function(){
            //クリックで動く$
            $('.nav-open').click(function(){
                $(this).toggleClass('active');
                $(this).next('nav').slideToggle();
            });
        });
    
        //ラジオボタン
        const element = document.getElementById('#onputradio');
        if(element){
            element.onclick = function() {

            var radiobox = document.createElement('input');
            radiobox.type = 'radio';
            radiobox.id = 'new-radio-button';
            radiobox.value = 'ラジオボタンの追加'

            var label = document.createElement('label');
            label.htmlFor = 'new-radio-button';
        
            var description = document.createTextNode('form');
            label.appendChild(description);
        
            var newline = document.createElement('br');
        
            var container = document.getElementById('container');
            container.appendChild(radio);
            // container.appendChild(label);
            container.appendChild(newline);
            }
        }
    });
    
    //カレンダー
    let date = document.querySelector(`input[type='date'][name='date']`);


// drop&drag

// ドラッグ要素のドラッグ開始時の処理
const $ = (id) => document.getElementById(id)
window.addEventListener('load', () => {
    const draggedItems = document.querySelectorAll('.dragged-item')
    for (const item of draggedItems) {
      item.draggable = true
      item.addEventListener('dragstart', (event) => {
        event.dataTransfer.setData('text/plain', event.target.id)
      })
    }
    $('drop-target').addEventListener('dragover', (event) => {
        event.preventDefault()
        event.dataTransfer.dropEffect = 'copy'
      })
    
      $('drop-target').addEventListener('drop', (event) => {
        let itemId = ''
        event.preventDefault()
    
        if (event.dataTransfer.items) {
          for (const item of event.dataTransfer.items) {
            const { kind, type } = item
            if (kind === 'file') {
              // Do nothing - item is file
            } else if (kind === 'string') {
              if (type === 'text/plain') {
                itemId = event.dataTransfer.getData(type)
              }
            }
          }
        }
    
        if (itemId !== '') {
          $('drop-target').innerHTML = $(itemId).innerHTML
        }
      })
    })
// document.querySelectorAll('.draggable').forEach(function(element) {
    // element.addEventListener('dragstart', function($event) {
      // ドラッグデータに要素のIDを設定
    //   $event.dataTransfer.setData('text/plain', $event.target.id);
    // });
//   });
  
  // ドロップエリアのドラッグオーバー時の処理
//   document.getElementById('dropZone').addEventListener('dragover', function($event) {
    // $event.preventDefault(); // デフォルトのドラッグオーバー動作をキャンセル
//   });
  
  // ドロップエリアのドロップ時の処理
//   document.getElementById('dropZone').addEventListener('drop', function($event) {
    // $event.preventDefault(); // デフォルトのドロップ動作をキャンセル
  
    // ドラッグデータから要素のIDを取得
    // var elementId = $event.dataTransfer.getData('text/plain');
  
    // 要素のコピーを作成
    // var copiedElement = document.getElementById(elementId).cloneNode(true);
  
    // コピーをドロップエリアに追加
    // this.appendChild(copiedElement);
//   });

    